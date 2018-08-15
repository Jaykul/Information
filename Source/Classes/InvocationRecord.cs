using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text;

namespace Information
{
    public class InvocationRecord : InformationRecord
    {
        public InvocationInfo Invocation { get; set; }

        public new DateTimeOffset TimeGenerated { get; set; }

        public new TimeSpan ElapsedTime { get; set; }

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
