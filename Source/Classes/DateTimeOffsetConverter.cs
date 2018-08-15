using System;
using System.Management.Automation;

namespace Information
{
	class DateTimeOffsetConverter : PSTypeConverter
	{
		public override bool CanConvertFrom(dynamic sourceValue, Type destinationType)
		{
			// We can convert it if it has the right properties
			try
			{
				sourceValue?.Ticks?.GetType();
				sourceValue?.Offset?.GetType();
			}
			catch
			{
				return false;
			}
			return true;
		}

		public override object ConvertFrom(dynamic sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
		{
			try
			{
				return new DateTimeOffset(sourceValue.Ticks, sourceValue.Offset);
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
