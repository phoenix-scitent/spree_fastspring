# SpreeFastspring

Allows for Fastspring integration into Spree for international purchases

## Installation

Add this line to your application's Gemfile:

    gem 'spree_fastspring'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spree_fastspring

## Usage

the PaymentMethod::Fastspring configurable should be directly available in spree admin payment methods.  Be sure to set up your gateway.

Also, be sure in your user model (where current_user reads from) to add an "should_checkout_with_fastspring?" logic block like follows:

  def should_checkout_with_fastspring?
  	return true
  end

In order for fastspring to actually work, youll need to create spree products, and assign the SKU of those products to
be identical to the product_ref from FastSpring

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
