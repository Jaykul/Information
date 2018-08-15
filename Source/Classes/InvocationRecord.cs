using System;
using System.Management.Automation;

namespace Information
{
	[System.ComponentModel.TypeConverter(typeof(InformationRecordConverter))]
	public class InvocationRecord : InformationRecord
    {
        public InvocationInfo Invocation { get; set; }

        public new DateTimeOffset TimeGenerated { get; set; }

        public TimeSpan ElapsedTime { get; set; }

        public InvocationRecord(object messageData, InvocationInfo invocation, string[] tags = null) : base(messageData, invocation.Line)
        {
            Invocation = invocation;
            if (tags != null)
            {
                Tags.AddRange(tags);
            }
        }

        public InvocationRecord(object messageData, string source) : base(messageData, source)
        {
            TimeGenerated = DateTimeOffset.Now;
            if (0 == InformationFormatter.StartTime.Ticks) {
                InformationFormatter.StartTime = TimeGenerated;
            }
            ElapsedTime = TimeGenerated - InformationFormatter.StartTime;
        }

        public string DisplayProperty
        {
            get
            {
                return this.FormatInformation();
            }
        }
    }
}
