module ArgumentMatchers
  class DateAroundMatcher

    # Takes an argument of expected date
    def initialize(expected)
      @expected = expected
    end

    # actual is a date (hopefully) passed to the method by the user.
    # We'll check if this date is 'around' expected date, where 'around' means
    # thay don't differ more than a second
    def ==(actual)
      if actual.kind_of? Time
         return (actual - @expected).abs < 1.second
      else
        return false
      end
    end

    def description
      "date around #{@expected}"
    end

  end

  # Usage:
  #  some_mock.should_receive(:message).with( date_around(Time.now) )
  def date_around(*args)
    DateAroundMatcher.new(*args)
  end
end