ActiveRecord::Schema.define(:version => 0) do

  create_table :invoices, :force => true do |t|
    t.integer   'invid'
    t.datetime  'invdate'
    t.float     'amount'
    t.float     'tax'
    t.float     'total'
    t.string    'note'
  end

end
