class Hash
  # Return a new hash with all keys converted using the block operation.
  #
  #  hash = { name: 'Rob', age: '28' }
  #
  #  hash.transform_keys{ |key| key.to_s.upcase }
  #  # => { "NAME" => "Rob", "AGE" => "28" }
  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

  # Destructively convert all keys using the block operations.
  # Same as transform_keys but modifies +self+.
  def transform_keys!
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end

  # Return a new hash with all keys converted to strings.
  #
  #   hash = { name: 'Rob', age: '28' }
  #
  #   hash.stringify_keys
  #   #=> { "name" => "Rob", "age" => "28" }
  def stringify_keys
    transform_keys{ |key| key.to_s }
  end

  # Destructively convert all keys to strings. Same as
  # +stringify_keys+, but modifies +self+.
  def stringify_keys!
    transform_keys!{ |key| key.to_s }
  end

  # Return a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+.
  #
  #   hash = { 'name' => 'Rob', 'age' => '28' }
  #
  #   hash.symbolize_keys
  #   #=> { name: "Rob", age: "28" }
  def symbolize_keys
    transform_keys{ |key| key.to_sym rescue key }
  end
  alias_method :to_options,  :symbolize_keys

  # Destructively convert all keys to symbols, as long as they respond
  # to +to_sym+. Same as +symbolize_keys+, but modifies +self+.
  def symbolize_keys!
    transform_keys!{ |key| key.to_sym rescue key }
  end
  alias_method :to_options!, :symbolize_keys!

  # Validate all keys in a hash match <tt>*valid_keys</tt>, raising ArgumentError
  # on a mismatch. Note that keys are NOT treated indifferently, meaning if you
  # use strings for keys but assert symbols as keys, this will fail.
  #
  #   { name: 'Rob', years: '28' }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key: years"
  #   { name: 'Rob', age: '28' }.assert_valid_keys('name', 'age') # => raises "ArgumentError: Unknown key: name"
  #   { name: 'Rob', age: '28' }.assert_valid_keys(:name, :age)   # => passes, raises nothing
  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!
    each_key do |k|
      raise ArgumentError.new("Unknown key: #{k}") unless valid_keys.include?(k)
    end
  end

  # Return a new hash with all keys converted by the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #
  #  hash = { person: { name: 'Rob', age: '28' } }
  #
  #  hash.deep_transform_keys{ |key| key.to_s.upcase }
  #  # => { "PERSON" => { "NAME" => "Rob", "AGE" => "28" } }
  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  # Destructively convert all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_transform_keys!(&block)
    _deep_transform_keys_in_object!(self, &block)
  end

  # Return a new hash with all keys converted to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #
  #   hash = { person: { name: 'Rob', age: '28' } }
  #
  #   hash.deep_stringify_keys
  #   # => { "person" => { "name" => "Rob", "age" => "28" } }
  def deep_stringify_keys
    deep_transform_keys{ |key| key.to_s }
  end

  # Destructively convert all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s }
  end

  # Return a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+. This includes the keys from the root hash
  # and from all nested hashes and arrays.
  #
  #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
  #
  #   hash.deep_symbolize_keys
  #   # => { person: { name: "Rob", age: "28" } }
  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym rescue key }
  end

  # Destructively convert all keys to symbols, as long as they respond
  # to +to_sym+. This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

  private
    # support methods for deep transforming nested hashes and arrays
    def _deep_transform_keys_in_object(object, &block)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[yield(key)] = _deep_transform_keys_in_object(value, &block)
        end
      when Array
        object.map {|e| _deep_transform_keys_in_object(e, &block) }
      else
        object
      end
    end

    def _deep_transform_keys_in_object!(object, &block)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
        end
        object
      when Array
        object.map! {|e| _deep_transform_keys_in_object!(e, &block)}
      else
        object
      end
    end
end
