ActiveRecord::Schema.define(:version => 0) do

  create_table :hickwalls, :force => true do |t|
    t.string :name
    t.string :last_squawk
    t.datetime :last_squawked_at
  end

  create_table :wickwalls, :force => true do |t|
    t.string :name
    t.string :last_tweet
    t.datetime :last_tweeted_at
  end

  create_table :woodpeckers, :force => true do |t|
    t.string :name
  end

end
