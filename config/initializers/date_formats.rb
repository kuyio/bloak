Time::DATE_FORMATS.merge!(
  friendly_short:    '%Y-%m-%d',
  datetime_military: '%Y-%m-%d %H:%M',
  datetime:          '%Y-%m-%d %I:%M%P',
  time:              '%I:%M%P',
  time_military:     '%H:%M%P',
  datetime_short:    '%m/%d %I:%M',
  friendly: lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y") },
)
