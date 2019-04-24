class MetroInfopoint
  def initialize(path_to_timing_file:, path_to_lines_file:)
    timing_data = YAML.load_file(path_to_timing_file)['timing']
    stations_data = YAML.load_file(path_to_lines_file)['stations']
    @stations = stations_data.keys.map { |k| k.to_sym }

    n = @stations.length
    @min_prices = Array.new(n) { Array.new(n, 1e100) }
    @min_times = Array.new(n) { Array.new(n, 1e100) }

    timing_data.each do |k|
      i = @stations.index(k['start'])
      j = @stations.index(k['end'])
      @min_prices[i][j] = @min_prices[j][i] = k['price']
      @min_times[i][j] = @min_times[j][i] = k['time']
    end

    (0...n).each do |k|
      (0...n).each do |i|
        (0...n).each do |j|
          if @min_times[i][j] > @min_times[i][k] + @min_times[k][j]
            @min_times[i][j] = @min_times[i][k] + @min_times[k][j]
          end
        end
      end
    end

    (0...n).each do |k|
      (0...n).each do |i|
        (0...n).each do |j|
          if @min_prices[i][j] > @min_prices[i][k] + @min_prices[k][j]
            @min_prices[i][j] = @min_prices[i][k] + @min_prices[k][j]
          end
        end
      end
    end
  end

  def calculate(from_station:, to_station:)
    { price: calculate_price(from_station: from_station, to_station: to_station),
      time: calculate_time(from_station: from_station, to_station: to_station) }
  end

  def calculate_price(from_station:, to_station:)
    from_index = @stations.index(from_station.to_sym)
    to_index = @stations.index(to_station.to_sym)
    @min_prices[from_index][to_index].round(5)
  end

  def calculate_time(from_station:, to_station:)
    from_index = @stations.index(from_station.to_sym)
    to_index = @stations.index(to_station.to_sym)
    @min_times[from_index][to_index].round(5)
  end
end