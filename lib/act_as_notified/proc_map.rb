# frozen_string_literal: true

module ActAsNotified
  class ProcMap

    def initialize
      @map = {}
    end

    def use(symbol, proc)
      raise ActAsNotified::BadConfiguration, "invalid number of parameters for 'use' in '#{symbol}'" if proc.arity != 1

      @map[symbol] = proc
    end

    def fetch(symbol)
      raise ActAsNotified::Error, "no map found for '#{symbol}'" if @map[symbol].nil?

      @map[symbol]
    end

    def count
      @map.count
    end

  end

end