using System;
using System.Management.Automation;

namespace Information
{
	class InformationRecordConverter : PSTypeConverter
	{
		public override bool CanConvertFrom(dynamic sourceValue, Type destinationType)
		{
			// We can convert it if it has the right properties
			try
			{
				sourceValue?.MessageData?.GetType();
				sourceValue?.Invocation?.GetType();
				sourceValue?.TimeGenerated?.GetType();
				sourceValue?.Tags?.GetType();
			}
			catch
			{
				return false;
			}
			return true;
		}

		public override object ConvertFrom(dynamic psSourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
		{
			try
			{
				if (destinationType == typeof(InvocationRecord))
				{
					return new InvocationRecord(psSourceValue.MessageData, psSourceValue.Invocation, psSourceValue.Tags)
					{
						TimeGenerated = psSourceValue.TimeGenerated
					};
				}
				else
				{
					var record = new InformationRecord(psSourceValue.MessageData, psSourceValue.Source)
					{
						TimeGenerated = psSourceValue.TimeGenerated
					};
					record.Tags.AddRange(psSourceValue.Tags);
					return record;
				}
			}
			catch
			{
				return null;
			}
		}
		public override bool CanConvertTo(object sourceValue, Type destinationType) => false;
		public override object ConvertTo(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase) => false;
	}
}
