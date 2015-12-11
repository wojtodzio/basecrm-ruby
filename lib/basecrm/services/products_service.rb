module BaseCRM
  class ProductsService
    OPTS_KEYS_TO_PERSIST = Set[:active, :description, :name, :sku, :prices, :max_discount, :max_markup, :cost, :cost_currency]

    def initialize(client)
      @client = client
    end
   
    # Retrieve all Products
    # 
    # get '/products'
    #
    # If you want to use filtering or sorting (see #where).
    # @return [Enumerable] Paginated resource you can use to iterate over all the resources. 
    def all
      PaginatedResource.new(self)
    end

    # Retrieve all products
    # 
    # get '/products'
    #
    # Returns all products, according to the parameters provided
    #
    # @param options [Hash] Search options
    # @option options [Boolean] :confirmed Indicator whether to return only confirmed product accounts or not.
    # @option options [String] :ids Comma-separated list of product IDs to be returned in a request.
    # @option options [String] :name Name of the product. This parameter is used in a strict sense.
    # @option options [Integer] :page (1) Page number to start from. Page numbering starts at 1, and omitting the `page` parameter will return the first page.
    # @option options [Integer] :per_page (25) Number of records to return per page. The default limit is *25*, and the maximum number that can be returned is *100*.
    # @option options [String] :sort_by (id:asc) A field to sort by. The **default** order is **ascending**. If you want to change the sort order to descending, append `:desc` to the field e.g. `sort_by=name:desc`.
    # @return [Array<Product>] The list of Products for the first page, unless otherwise specified.  
    def where(options = {})
      _, _, root = @client.get("/products", options)
      
      root[:items].map{ |item| Product.new(item[:data]) }
    end

    # Retrieve a single product
    # 
    # get '/products/{id}'
    #
    # Returns a single product according to the unique product ID provided
    # If the specified product does not exist, this query returns an error
    #
    # @param id [Integer] Unique identifier of a Product
    # @return [Product] Searched resource object. 
    def find(id)
      _, _, root = @client.get("/products/#{id}")

      Product.new(root[:data])
    end

    def create(product)
      validate_type!(product)

      attributes = sanitize(product)
      _, _, root = @client.post("/products", attributes)

      Product.new(root[:data])
    end

  private
    def validate_type!(product)
      raise TypeError unless product.is_a?(Product) || product.is_a?(Hash)
    end

    def extract_params!(product, *args)
      params = product.to_h.select{ |k, _| args.include?(k) }
      raise ArgumentError, "one of required attributes is missing. Expected: #{args.join(',')}" if params.count != args.length
      params
    end

    def sanitize(product)
      product.to_h.select { |k, _| OPTS_KEYS_TO_PERSIST.include?(k) }
    end
  end
end
