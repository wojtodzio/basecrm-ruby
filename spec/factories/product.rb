FactoryGirl.define do
  factory :product, class: BaseCRM::Product do

    active { true }
    description { "Product description"  }
    name { "Product" }
    sku { "1000" }
    prices { [{currency: "EUR", amount: "1000.00"}] }
    max_discount { 10 }
    max_markup { 10 }
    cost { 1000 }
    cost_currency { "EUR" }

    to_create do |product|
      client.products.create(product)
    end
  end
end
