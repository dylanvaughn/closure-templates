class Person

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def age
    35
  end

  def first_name
    @first_name
  end

  def last_name
    @last_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def attributes
    {
      "first_name" => first_name,
      "last_name" => last_name,
      "full_name" => full_name,
      "age" => age
    }
  end

end
