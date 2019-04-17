# frozen_string_literal: true

module Renderful
  class Cache
    def exist?(_key)
      raise NotImplementedError
    end

    def read(_key)
      raise NotImplementedError
    end

    def write(_key, _value)
      raise NotImplementedError
    end

    def delete(_key)
      raise NotImplementedError
    end
  end
end
