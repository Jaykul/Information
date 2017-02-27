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
    public class InformationMessage {
        /// <summary>
        /// Keep track of when the current invocation started
        /// </summary>
        public static DateTimeOffset StartTime { get; set; }

        /// <summary>
        /// Track the console display width
        /// </summary>
        public static int ExceptionWidth { get; set; }

        /// <summary>
        /// The template for formatting the display string
        /// </summary>
        public static string InfoTemplate { get; set; }

        static InformationMessage()
        {
            StartTime = DateTimeOffset.MinValue;
            ExceptionWidth = 120;
            InfoTemplate = "{ClockTime}{Indent}{Message} <{Command}> {ScriptName}:{LineNumber}";
        }

        /// <summary>
        /// A prefix to use when converting to string
        /// </summary>
        public string PSComputerName { get; set; }

        /// <summary>
        /// If set, shows the exception stack
        /// </summary>
        public bool ShowException { get; set; }

        /// <summary>
        /// A prefix to use when converting to string
        /// </summary>
        public string Prefix { get; set; }

        // The Time is here so we can use it in the InfoTemplate
        /// <summary>
        /// The full date and time when this message was generated
        /// </summary>
        private DateTimeOffset _generatedDateTime;
        public DateTimeOffset GeneratedDateTime
        {
            get
            {
                return _generatedDateTime;
            }
            set
            {
                _generatedDateTime = value;
                if (DateTimeOffset.MinValue == StartTime)
                {
                    StartTime = _generatedDateTime;
                }
                ElapsedTime = _generatedDateTime - StartTime;
            }
        }

        /// <summary>
        /// The difference between the time this was generated and the start time
        /// </summary>
        public TimeSpan ElapsedTime { get; set; }
        /// <summary>
        /// The Time portion of TimeGenerated
        /// </summary>
        public TimeSpan ClockTime { get { return GeneratedDateTime.TimeOfDay; } }

        // The mandatory constructor parameters
        /// <summary>
        /// The original message object passed to Write-Info
        /// </summary>
        public PSObject MessageData { get; set; }

        /// <summary>
        /// The (script) callstack at the point of creation
        /// </summary>
        private Array _callstack;

        public Array CallStack
        {
            get { return _callstack; }
            set {
                _callstack = value;
                if ((_callstack is string[]))
                {
                    var stack = new List<string>();
                    foreach (string frames in _callstack)
                    {
                        stack.AddRange(frames.Split(new char[] { '\r', '\n' }, options: StringSplitOptions.RemoveEmptyEntries));
                    }
                    _callstack = stack.ToArray();
                }

                var frame = _callstack.GetValue(0) as CallStackFrame;
                if (null != frame)
                {
                    FunctionName = frame.FunctionName.Trim('<','>');
                    ScriptPath = frame.ScriptName;
                    LineNumber = frame.ScriptLineNumber;

                    if (null == frame.InvocationInfo)
                    {
                        Command = FunctionName;
                    }
                    else
                    {
                        var commandInfo = frame.InvocationInfo.MyCommand;
                        if (null == commandInfo)
                        {
                            Command = frame.InvocationInfo.InvocationName;
                        }
                        else if (!string.IsNullOrEmpty(commandInfo.Name))
                        {
                            Command = commandInfo.Name;
                        }
                        else
                        {
                            Command = FunctionName;
                        }
                    }

                    Location = frame.GetScriptLocation();
                }
                else
                {
                    Location = _callstack.GetValue(0).ToString();

                    var position = Location.Split(new[] { "at ", ", ", ": line " }, StringSplitOptions.RemoveEmptyEntries);
                    if (position.Length > 2)
                    {
                        try
                        {
                            LineNumber = int.Parse(position[2]);
                        }
                        catch
                        {
                            LineNumber = 0;
                        }
                    }
                    if(position.Length > 1)
                    {
                        ScriptPath = position[1];
                    }
                    if (position.Length > 0)
                    {
                        FunctionName = position[0];
                    }

                    Command = FunctionName;
                 }
            }
        }
        /// <summary>
        /// The call stack depth (mostly for the purpose of indenting in the <see cref="InfoTemplate"/>)
        /// </summary>
        public int CallStackDepth { get { return CallStack.Length; } }

        // Calculated based on the MessageData
        /// <summary>
        /// The display string, based on the InfoTemplate and all the other properties
        /// </summary>
        public String Message { get; set; }

        // Calculated based on CallStack
        /// <summary>
        /// The name of the function the Information was written from
        /// </summary>
        public string FunctionName { get; private set; }

        /// <summary>
        /// The script file path the Information was written from
        /// </summary>
        public string ScriptPath { get; private set; }

        /// <summary>
        /// The script file name the Information was written from
        /// </summary>
        public string ScriptName
        {
            get
            {
                if (string.IsNullOrEmpty(ScriptPath)) {
                    return ".";
                } else {
                    return ScriptPath.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).Last();
                }
            }
        }

        /// <summary>
        /// The line of the script file the Information was written from
        /// </summary>
        public int LineNumber { get; private set; }

        /// <summary>
        /// The line position the information was written from
        /// </summary>
        public string Location { get; private set; }

        /// <summary>
        /// The command the information was written from
        /// </summary>
        public string Command { get; private set; }

        /// <summary>
        /// The single constructor, so that messageData and callStack must be passed
        /// </summary>
        /// <param name="messageData"></param>
        /// <param name="callStack"></param>
        /// <param name="prefix"></param>
        /// <param name="simple"></param>
        public InformationMessage(PSObject messageData, Array callStack, string prefix = "", bool simple = false)
        {
            PSComputerName = Environment.GetEnvironmentVariable("ComputerName");
            ShowException = !simple;
            Prefix = prefix ?? "";
            GeneratedDateTime = DateTimeOffset.Now;

            if (messageData.BaseObject is ActionPreferenceStopException && null != ((ActionPreferenceStopException)messageData.BaseObject).ErrorRecord) {
                MessageData = new PSObject(((ActionPreferenceStopException)messageData.BaseObject).ErrorRecord);
            }
            else
            {
                MessageData = messageData;
            }
            
            CallStack = callStack;
        }

        public override string ToString()
        {
            var msg = new StringBuilder();
            if(MessageData.BaseObject is string)
            {
                if (!string.IsNullOrEmpty(Prefix)) {
                    msg.Append(Prefix);
                }

                var stringMessage = MessageData.BaseObject.ToString().Trim();
                msg.Append(stringMessage);

                if (stringMessage.Contains("\n"))
                {
                    msg.Append("\n        ");
                }
                Message = msg.ToString();
                return ExpandTemplate();
            }

            if (string.IsNullOrEmpty(Prefix))
            {
                if (MessageData.TypeNames.Any(name => name.Contains("System.Management.Automation.RemotingErrorRecord")))
                {
                    msg.Append("REMOTE ERROR: ");
                }
                else if (MessageData.TypeNames.Any(name => name.Contains("System.Management.Automation.ErrorRecord")))
                {
                    msg.Append("MessageData: ");
                }
                else if (MessageData.TypeNames.Any(name => name.Contains("Exception")))
                {
                    msg.Append("EXCEPTION: ");
                }
            }
            else
            {
                    msg.Append(Prefix);
            }

            // This has to work with both Exceptions and Deserialized Exceptions
            if (ShowException) {
                msg.Append(ExpandException(MessageData));
            }
            else
            {
                msg.AppendFormat("[{0}]\n\n", MessageData.TypeNames.First());
                string MessageDataString;
                if (LanguagePrimitives.TryConvertTo<string>(MessageData, out MessageDataString))
                {
                    msg.AppendLine(MessageDataString);
                }
                else
                {
                    foreach (var property in MessageData.Properties)
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

            Message = msg.ToString();

            return ExpandTemplate();
        }

        public static string ExpandException(PSObject error)
        {
            var msg = new StringBuilder();
            if (!error.TypeNames.Any(name => name.Contains("System.Management.Automation.ErrorRecord") || name.Contains("System.Exception")))
            {
                msg.AppendFormat("[{0}]\n\n", error.TypeNames.First());
                string errorString;
                if(LanguagePrimitives.TryConvertTo<string>(error, out errorString))
                {
                    msg.AppendLine(errorString);
                }
                else
                {
                    foreach (var property in error.Properties)
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

            return msg.ToString();
        }

        private string ExpandTemplate() {
            var message = InfoTemplate;

            message = Regex.Replace(message, @"{ClockTime}", ClockTime.ToString(@"hh\:mm\:ss\.ffffff"), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{ClockTime:(.+?)}", m => ClockTime.ToString(m.Groups[1].Value.Replace(":",@"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{ElapsedTime}", ElapsedTime.ToString(@"hh\:mm\:ss\.ffffff"), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{ElapsedTime:(.+?)}", m => ElapsedTime.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{GeneratedDateTime}", GeneratedDateTime.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{GeneratedDateTime:(.+?)}", m => GeneratedDateTime.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);

            message = Regex.Replace(message, @"{PSComputerName}", PSComputerName.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{CallStack}", CallStack.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{Command}", Command.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{FunctionName}", FunctionName.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{Indent}", " ".PadLeft(CallStackDepth * 2), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{LineNumber}", LineNumber.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{Location}", Location.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{Message}", Message.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{ScriptName}", ScriptName.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{ScriptPath}", ScriptPath.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"{TimeGenerated}", GeneratedDateTime.ToString(), RegexOptions.IgnoreCase);

            message = Regex.Replace(message, @"`e", "\u001b", RegexOptions.IgnoreCase);

            return message;
        }
    }
}

/*


    hidden [void] init([PSObject]$MessageData, [Array]$CallStack, [string]$Prefix, [bool]$Simple) {
        Write-Warning "ENTER init Information.InformationMessage($MessageData, $CallStack)"



    }

    [string]ToString() {

        $e = [char]27
        # Copy everything into local variables so they work in ExpandString
        $local:MessageData = $this.MessageData
        $local:Message = $this.Message
        $local:CallStack = $this.CallStack
        $local:TimeGenerated = $this.TimeGenerated
        $local:ElapsedTime = $this.ElapsedTime
        $local:Time = $this.Time
        $local:FunctionName = $this.FunctionName
        $local:ScriptPath = $this.ScriptPath
        $local:LineNumber = $this.LineNumber
        $local:Command = $this.Command
        $local:Location = $this.Location
        $local:Arguments = $this.Arguments
        $local:ScriptName = $this.ScriptName
        $local:CallStackDepth = $this.CallStackDepth

        try {
            return (Get-Variable ExecutionContext -ValueOnly).InvokeCommand.ExpandString( [Information.InformationMessage]::InfoTemplate )
        } catch {
            Write-Warning $_
            return "{0} {1} at {2}" -f $this.Time, $this.Message, $this.Location
        }
    }
}

Update-TypeData -TypeName Information.InformationMessage -SerializationMethod 'AllPublicProperties' -SerializationDepth 4 -Force
Update-TypeData -TypeName System.Management.Automation.InformationRecord -SerializationMethod 'AllPublicProperties' -SerializationDepth 6 -Force
 */
