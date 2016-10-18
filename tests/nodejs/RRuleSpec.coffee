expect = require('chai').expect
_ = require('underscore')
TimeZoneDate = require('tz-date')
RRule = require('../../lib/rrule').RRule

describe 'RRule', ->

  it 'can generate dates', ->
    recurrence = 'FREQ=WEEKLY;INTERVAL=1;BYDAY=FR;TIMEZONE=Australia/Melbourne;DTSTART=20150612T011442Z'
    #recurrence = 'FREQ=WEEKLY;INTERVAL=1;BYDAY=FR'
    # rule = DateUtils.createRRuleWithStartDate(recurrence, new Date('Fri Jun 12 2015 11:14:42 GMT+1000 (AEST)'))

    # rule = DateUtils.createRRuleFromString(recurrence, {dtstart: new Date('Fri Jun 12 2015 11:14:42 GMT+1000 (AEST)')})
    # rule = DateUtils.createRRuleFromStringAndStartDate(recurrence, new Date('Fri Jun 12 2015 11:14:42 GMT+1000 (AEST)'))
    # rule = DateUtils.createRRuleFromStringAndStartDate(recurrence, new Date('Fri Jun 12 2015 11:14:42 GMT+1000 (AEST)'))
    # rule = DateUtils.createRRuleFromStringAndStartDate(recurrence, '2015-06-12T11:14:42+10:00')
    dt = DateUtils.createDate('2015-06-12T11:14:42+10:00')
    console.log("DEBUG: dt formatted", dt._moment.format());
    rule = DateUtils.createRRuleFromStringAndStartDate(recurrence, dt)
    expect(rule.toString() == recurrence)
    console.log("DEBUG: rrule", rule.toString())
    startDate = new TimeZoneDate('2015-12-31T00:00:00+11:00')
    endDate = new TimeZoneDate('2016-01-07T23:59:59+11:00')
    ruleStartDate = rule.options.dtstart
    console.log('DEBUG: ruleStartDate', ruleStartDate._moment.format())
    console.log('DEBUG: startDate', startDate.toString())
    console.log('DEBUG: endDate', endDate.toString())
    console.log('DEBUG: rule', rule.toString())
    console.log('DEBUG: ruleStartDate', ruleStartDate.toString())
    dates = []
    rule.between ruleStartDate, endDate, true, (occurrence, i) ->
      console.log("Occurrence", occurrence.toString())
      dates.push(occurrence)
      # Continue iterating.
      return true
    expect(_.first(dates).toString()).to.equal('Fri Jun 12 2015 11:14:42 GMT+1000 (AEST)')
    expect(_.last(dates).toString()).to.equal('Fri Jan 01 2016 11:14:42 GMT+1100 (AEDT)')




# AUXILIARY

DateUtils =

  # Index 0 is Monday for RRule, Sunday for Date.

  # @param {Number} dateIndex - The day index in the RRule format.
  # @returns {Number} The given index in the format used by Date.
  fromRRuleDayIndex: (dateIndex) -> (dateIndex + 1) % (Dates.MAX_DAY_INDEX + 1)

  # @param {Number} dateIndex - The day index in the Date format.
  # @returns {Number} The given index in the format used by RRule.
  toRRuleDayIndex: (dateIndex) -> (dateIndex + Dates.MAX_DAY_INDEX) % (Dates.MAX_DAY_INDEX + 1)

  # @param {Object} args
  # @returns {RRule} An RRule with the correct time zone.
  createRRule: (args) ->
    args ?= {}
    _.defaults args, @_getRRuleArgs()
    new RRule(args)

  # @param {String|RRule} [str] - A serialized RRule, or an RRule object.
  # @returns {RRule} An RRule with the correct time zone.
  createRRuleFromString: (str, args) ->
    if str instanceof RRule then str = str.toString()
    rule = RRule.fromString(str)
    console.log('TEST: rrule from string', rule)
    # Additional args may not be serialized, so apply them and clone again.
    _.defaults rule.origOptions, @_getRRuleArgs()
    _.extend rule.origOptions, args
    rule.clone()

  createRRuleFromStringAndStartDate: (str, date) ->
    dtstart = if date instanceof TimeZoneDate then date else @createDate(date)
    console.log('DEBUG: dtstart', dtstart._moment.format())
    @createRRuleFromString(str, {dtstart: dtstart})

  createDate: (date, timeZone) ->
    timeZone ?= @getTimeZone()
    console.log("DEBUG: creating date with", date, timeZone)
    new TimeZoneDate(date, timeZone)

  createMoment: (date, timeZone) ->
    timeZone ?= @getTimeZone()
    moment.tz(date, timeZone)

  createLocalMoment: (date, timeZone) -> @createMoment(Dates.toLocal(date), timeZone)

  format: (date, timeZone) ->
    timeZone ?= @getTimeZone()
    moment.tz(date, timeZone).format()

  getTimeZone: -> 'Australia/Melbourne'

  _getRRuleArgs: ->
    timezone: @getTimeZone()

RRule?.setDateClass(TimeZoneDate)
