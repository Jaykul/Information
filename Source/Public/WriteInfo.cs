using System;
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;

namespace Information
{
    [Cmdlet(VerbsCommunications.Write, "Information")]
    public class WriteInformationCommand : PSCmdlet
    {
        /// <summary>
        /// Object to be sent to the Information stream.
        /// </summary>
        [Parameter(Position = 0, Mandatory = true, ValueFromPipeline = true)]
        [Alias("Msg", "Message")]
        public PSObject MessageData { get; set; }

        /// <summary>
        /// Any tags to be associated with this information
        /// </summary>
        [Parameter(Position = 1)]
        [SuppressMessage("Microsoft.Performance", "CA1819:PropertiesShouldNotReturnArrays")]
        public string[] Tags { get; set; }


        /// <summary>
        /// A time to use as the "Start" time for the InformationHelper formatter
        /// </summary>
        [Parameter]
        DateTimeOffset StartTime { get; set; } = DateTimeOffset.MinValue;

        /// <summary>
        /// This method implements the processing of the Write-Information command
        /// </summary>
        protected override void BeginProcessing()
        {
            if (DateTimeOffset.MinValue != StartTime)
            {
                InformationFormatter.StartTime = StartTime;
            }
        }

        /// <summary>
        /// This method implements the ProcessRecord method for Write-Information command
        /// </summary>
        protected override void ProcessRecord()
        {
            var info = new InvocationRecord(MessageData, MyInvocation, Tags);
            WriteInformation(info);
        }
    }
}
