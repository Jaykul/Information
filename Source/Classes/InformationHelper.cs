using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Text.RegularExpressions;

namespace Information {
    public static class InformationFormatter {
        /// <summary>
        /// Keep track of when the current invocation started
        /// </summary>
        public static DateTimeOffset StartTime { get; set; } = DateTimeOffset.MinValue;

        /// <summary>
        /// Track the console display width
        /// </summary>
        public static int ExceptionWidth { get; set; } = 120;

        /// <summary>
        /// The template for formatting the display string
        /// </summary>
        public static string InfoTemplate { get; set; } = "{ClockTime} {Message} {PositionMessage}";

        /// <summary>
        /// Render an InvocationRecord using a template string
        /// </summary>
        /// <param name="record">The informationRecord</param>
        /// <param name="template">An override template string</param>
        /// <returns>A formatted string representation of the InvocationRecord</returns>
        public static string FormatInformation(this InformationRecord record, string template = null)
        {
            var message = template ?? InfoTemplate;
            message = Regex.Replace(message, @"{Message}", ExpandMessageData(record.MessageData), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"`e", "\u001b", RegexOptions.IgnoreCase);

            // supported by default InformationRecord
            message = Regex.Replace(message, @"{ClockTime}", record.TimeGenerated.TimeOfDay.ToString(@"hh\:mm\:ss\.ffffff"), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{ClockTime:(.+?)}", m => record.TimeGenerated.TimeOfDay.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{TimeGenerated}", record.TimeGenerated.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{TimeGenerated:(.+?)}", m => record.TimeGenerated.TimeOfDay.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{Computer}", record.Computer, RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{User}", record.User, RegexOptions.IgnoreCase);

            // requires InvocationRecord
            if(record is InvocationRecord invocation)
            {
                message = Regex.Replace(message, @"{ElapsedTime}", invocation.ElapsedTime.ToString(@"hh\:mm\:ss\.ffffff"), RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{ElapsedTime:(.+?)}", m => invocation.ElapsedTime.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);

                message = Regex.Replace(message, @"{Command}", (string)LanguagePrimitives.ConvertTo(invocation.Invocation.MyCommand, typeof(string)), RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{CommandName}", invocation.Invocation.MyCommand.Name, RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{CommandPath}", (string)LanguagePrimitives.ConvertTo(invocation.Invocation.PSCommandPath, typeof(string)), RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{ScriptLineNumber}", invocation.Invocation.ScriptLineNumber.ToString(), RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{ScriptName}", invocation.Invocation.ScriptName, RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{Position}", invocation.Invocation.PositionMessage.Split('\r', '\n')[0].ToString(), RegexOptions.IgnoreCase);
                message = Regex.Replace(message, @"{PositionMessage}", invocation.Invocation.PositionMessage, RegexOptions.IgnoreCase);
            }
            return message;
        }

        private static string ExpandMessageData(object messageData)
        {
            var msg = new StringBuilder();
            (PSObject metaData, object baseObject) = (messageData is PSObject data) ? 
                                                        (data, data.BaseObject) : 
                                                        (new PSObject(messageData), messageData);

            if (metaData.TypeNames.Any(name => name.Contains("System.Management.Automation.RemotingErrorRecord")))
            {
                msg.Append("REMOTE ERROR: ");
                ExpandError(metaData, msg);
            }
            else if (metaData.TypeNames.Any(name => name.Contains("System.Management.Automation.ErrorRecord")))
            {
                msg.Append("ERROR: ");
                ExpandError(metaData, msg);
            }
            else if (metaData.TypeNames.Any(name => name.Contains("Exception")))
            {
                msg.Append("EXCEPTION: ");
                ExpandError(metaData, msg);
            }
            else if (baseObject is string)
            {
                var stringMessage = baseObject.ToString().Trim();
                msg.Append(stringMessage);

                if (stringMessage.Contains("\n"))
                {
                    msg.Append("\n        ");
                }
            }
            else if (LanguagePrimitives.TryConvertTo(baseObject, out string MessageDataString))
            {
                msg.AppendLine(MessageDataString);
            }
            else { 
                foreach (var property in metaData.Properties)
                {
                    // This list is types which aren't worth displaying without a label
                    if (!(property.Value is Boolean || property.Value is Byte || property.Value is SByte || property.Value is Char || property.Value is Single || property.Value is Int16 || property.Value is UInt16 || property.Value is Int32 || property.Value is UInt32 || property.Value is Int64 || property.Value is UInt64 || property.Value is Double || property.Value is Decimal))
                    {
                        msg.AppendFormat("{0} ", property.Value);
                    }
                }
            }

            return msg.ToString();
        }

        private static void ExpandError(PSObject error, StringBuilder msg)
        {
            msg.AppendLine(error.Properties.Any(p => p.Name == "Exception") ?
                            new PSObject(error.Properties.First(p => p.Name == "Exception").Value).Properties.First(p => p.Name == "Message").Value.ToString() :
                            error.Properties.First(p => p.Name == "Message").Value.ToString());
            msg.AppendLine();

            // Render the nested errors directly into the message
            var width = ExceptionWidth;
            var level = 1;
            var left = 0;
            while (null != error)
            {
                PSObject next = null;
                var stackTrace = new StringBuilder();
                msg.AppendFormat("{0}[{1}]\n\n", " ".PadLeft(level * 4), error.TypeNames.First(name => name.Contains("System.Management.Automation.ErrorRecord") || name.Contains("System.Exception")));
                // I'm hard-coding skipping this one property because it's name is long and it's pointless
                left = error.Properties.Max(p => p.Name.Contains("WasThrownFromThrowStatement") ? 0 : p.Name.Length);
                foreach (var property in error.Properties)
                {
                    if (string.IsNullOrWhiteSpace("" + property.Value) || property.Name == "WasThrownFromThrowStatement")
                    {
                        continue;
                    }

                    if ((property.Name == "Exception" || property.Name == "InnerException") && property.Value != null)
                    {
                        next = new PSObject( property.Value );
                    }
                    else if (property.Name.EndsWith("StackTrace"))
                    {
                        // we track the stacktrace separately so we can put it last, because it's multi-line
                        var value = ("" + property.Value).Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

                        stackTrace.AppendLine(" ".PadLeft(level * 4) + (property.Name).PadRight(left) + " : " + value.First());

                        foreach (var additional in value.Skip(1))
                        {
                            stackTrace.AppendLine(" ".PadLeft((level * 4) + left + 3 ) + additional.Trim());
                        }
                    }
                    else
                    {
                        msg.AppendLine(" ".PadLeft(level * 4) + (property.Name).PadRight(left) + " : " + property.Value);
                    }
                }
                // Stick a blank line on the end ... after the stackTrace
                msg.AppendLine(stackTrace.ToString());
                error = next;
                level++;
                width -= 4;
            }
            msg.Append(" ".PadLeft((level * 4)));
        }
    }
}