require File.dirname(__FILE__) + '/work_day'



# encapsulates the start and end times for a working day
class WorkDay
    
    attr_reader :start_time, :end_time
    
    def initialize(start_time, end_time)
        if start_time.nil? && end_time.nil?
            @working_day = false
            @start_time = WorkTime.new(0,0)
            @end_time = WorkTime.new(0,0)
        else
            raise 'Start time must be a WorkTime object' unless start_time.is_a?(WorkTime)
            raise 'End time must be a WorkTime object' unless end_time.is_a?(WorkTime)
            raise 'End time must be after start time' unless end_time.minutes > start_time.minutes
            @working_day = true
            @start_time = start_time
            @end_time = end_time
        end
    end
    
    
    def working_day?
        @working_day
    end
    
    def start_in_minutes
        @start_time.minutes
    end
    
    def end_in_minutes
        @end_time.minutes
    end
    
    # returns true if the given work time object represents a time during working hours
    def includes?(work_time)
        return false if work_time.minutes < @start_time.minutes
        return false if work_time.minutes > @end_time.minutes
        return true
    end
        
        
    def to_s
        "#{@start_time} - #{@end_time}"
    end
    
end
    
    
    