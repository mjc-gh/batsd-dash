# helpers for parsing and validating input
module BatsdDash
  module GraphHelper
    ##
    # This method works directly against values. It will tranform all
    # datapoint to an array where the first element is a milisecond
    # timestamp and the second is a float value data point.
    def values_for_graph(values, opts = {})
      return values if values.empty?

      values.tap do |pts|
        step = opts[:interval] * 1000
        range = opts[:range]

        # transform the first point
        transform_point_at!(0, values)

        # start from the first timestamp
        time = values.first.first + step
        index = 0

        # loop through values to transform and zerofill
        while index < values.size - 1
          obj = transform_point_at!(index += 1, values)

          if obj.first <= time
            time += step
            next
          end

          # need to insert zerofilled point (if zerofill is enabled)
          values.insert(index, [time, 0]) if opts[:zero_fill]
          time += step
        end
      end
    end

    ##
    # Transform a point at a given index
    def transform_point_at!(index, values)
      data_pt = values[index]

      # we've already transformed this index (must be zerofill)
      return data_pt unless Hash === data_pt

      pt_time = data_pt['timestamp'].to_i * 1000
      pt_value = data_pt['value'].to_f

      values[index] = [pt_time, pt_value]
    end
  end
end
