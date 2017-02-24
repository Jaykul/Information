using System;
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
        /// If set, shows the exception stack
        /// </summary>
        public bool ShowException { get; private set; }

        /// <summary>
        /// A prefix to use when converting to string
        /// </summary>
        public string Prefix { get; private set; }

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
            InfoTemplate = @"$('{0:hh\:mm\:ss\.fff}' -f ${Time})$(' ' * $CallStackDepth)${Message} <${Command}> ${ScriptName}:${LineNumber}";
        }

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
                var frame = _callstack.GetValue(0) as CallStackFrame;
                if (null != frame)
                {
                    FunctionName = frame.FunctionName.Trim('<','>');
                    ScriptPath = frame.ScriptName;
                    LineNumber = frame.ScriptLineNumber;

                    if (null == frame.InvocationInfo)
                    {
                        Command = frame.FunctionName;
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
                            Command = frame.FunctionName;
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

        // The Time is here so we can use it in the InfoTemplate
        /// <summary>
        /// The full date and time when this message was generated
        /// </summary>
        public DateTimeOffset GeneratedDateTime { get; set; }
        /// <summary>
        /// The difference between the time this was generated and the start time
        /// </summary>
        public TimeSpan ElapsedTime { get { return StartTime - GeneratedDateTime; } }
        /// <summary>
        /// The Time portion of TimeGenerated
        /// </summary>
        public TimeSpan ClockTime { get { return GeneratedDateTime.TimeOfDay; } }

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
        /// The call stack depth (mostly for the purpose of indenting in the <see cref="InfoTemplate"/>)
        /// </summary>
        public int CallStackDepth { get { return CallStack.Length; } }

        public InformationMessage(PSObject messageData, Array callStack, string prefix = "", bool simple = false)
        {
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

            if ((callStack is string[]))
            {
                var stack = new List<string>();
                foreach (string frame in callStack)
                {
                    stack.AddRange(frame.Split(new char[] { '\r', '\n' }, options: StringSplitOptions.RemoveEmptyEntries));
                }
                CallStack = stack.ToArray();
            }
            else
            {
                CallStack = callStack;
            }

            if (DateTimeOffset.MinValue == StartTime)
            {
                StartTime = GeneratedDateTime;
            }
        }

        public override string ToString()
        {
            var msg = new StringBuilder();
            if (!string.IsNullOrEmpty(Prefix)) {
                msg.Append(Prefix);
            }

            if (!(MessageData.BaseObject is string))
            {
                if (!string.IsNullOrEmpty(Prefix))
                {
                    if (MessageData.BaseObject is RemotingErrorRecord)
                    {
                        msg.Append("REMOTE ERROR: ");
                    }
                    else if (MessageData.BaseObject is ErrorRecord)
                    {
                        msg.Append("ERROR: ");
                    }
                    else if (MessageData.BaseObject is Exception)
                    {
                        msg.Append("EXCEPTION: ");
                    }
                }
                foreach (var property in MessageData.Properties)
                {
                    msg.AppendFormat("{0} ", property.Value);
                }
            }
            else
            {
                var stringMessage = MessageData.BaseObject.ToString().Trim();
                msg.Append(stringMessage);
                if (stringMessage.Contains("\n"))
                {
                    msg.Append("\n        ");
                }
            }

            if (ShowException) {
                PSObject err = null;

                if (MessageData.BaseObject is ErrorRecord || MessageData.BaseObject is Exception)
                {
                    err = MessageData;
                    msg.Append("\n\n");
                }

                // Render the nested errors directly into the message
                var width = ExceptionWidth;
                var level = 1;
                while (null != err) {
                    Exception next = null;

                    msg.AppendFormat("{0}[{1}]\n", " ".PadLeft(level), err.TypeNames[0]);
                    foreach (var property in err.Properties)
                    {
                        if (property.Name == "Exception" || property.Name == "InnerException")
                        {
                            next = property.Value as Exception;
                        }
                        msg.AppendFormat("{0}{1}: {2}\n", " ".PadLeft(level), property.Name, property.Value);
                    }
                    msg.AppendLine("`n`n`n");

                    err = next != null ? new PSObject(next) : null;
                    level++;
                    width -= 4;
                }
            }

            Message = msg.ToString();

            var message = InfoTemplate;
            
            message = Regex.Replace(message, @"\${ClockTime(?::(.+?))?}", m => ClockTime.ToString(m.Groups[1].Value.Replace(":",@"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${ElapsedTime(?::(.+?))?}", m => ElapsedTime.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${GeneratedDateTime(?::(.+?))?}", m => GeneratedDateTime.ToString(m.Groups[1].Value.Replace(":", @"\:").Replace(".", @"\.").Replace("-", @"\-")), RegexOptions.IgnoreCase);

            message = Regex.Replace(message, @"\${CallStack}", CallStack.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${Command}", Command.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${FunctionName}", FunctionName.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${Indent}", " ".PadLeft(CallStackDepth * 2), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${LineNumber}", LineNumber.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${Location}", Location.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${Message}", Message.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${ScriptName}", ScriptName.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${ScriptPath}", ScriptPath.ToString(), RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\${TimeGenerated}", GeneratedDateTime.ToString(), RegexOptions.IgnoreCase);

            var env = Environment.GetEnvironmentVariables();
            foreach (var ev in env.Keys)
            {
                message = Regex.Replace(message, @"\${Env:" + ev + "}", (string)env[ev], RegexOptions.IgnoreCase);
            }

            message = Regex.Replace(message, @"\${e}", "\u001b", RegexOptions.IgnoreCase);
            message = Regex.Replace(message, @"\$e\b", "\u001b", RegexOptions.IgnoreCase);
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