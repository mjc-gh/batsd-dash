# helpers for parsing and validating input
module BatsdHelper
  module Graph
    ##
    # This method works directly against values
    def collect_for_graph(values, opts = {})
      values.tap do |pts|
        # remap the values
        pts.map! { |pt| [pt['timestamp'].to_i * 1000, pt['value'].to_f] }

        # apply zerofill
        zero_fill!(pts, opts[:range], opts[:interval]) unless pts.empty? || !opts[:zero_fill]
      end
    end

    ##
    # The data better be normalized to the interval otherwise
    # this method may get pissed
    def zero_fill!(values, range, step)
      return values if step.zero?

      # convert to milisec
      step *= 1000

      values.tap do |data|
        # start from the first timestamp
        time = data.first.first + step
        index = 0

        while obj = data[index += 1]
          if obj.first == time
            time += step
            next
          end

          data.insert(index, [time, 0])

          time += step
        end
      end
    end
  end
end
