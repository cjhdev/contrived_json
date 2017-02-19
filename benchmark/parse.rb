require 'rubygems'
require 'benchmark'
require 'json'
#require 'yajl'
require 'contrived_json'

# taken from yajl
data =
'{"item": {"name": "generated", "cached_tag_list": "", "updated_at": "2009-03-24T05:25:09Z", "updated_by_id": null, "price": 1.99, "delta": false, "cost": 0.597, "account_id": 16, "unit": null, "import_tag": null, "taxable": true, "id": 1, "created_by_id": null, "description": null, "company_id": 0, "sku": "06317-0306", "created_at": "2009-03-24T05:25:09Z", "active": true}}'.freeze

times = 10000

Benchmark.bmbm do |x|

  if defined?(JSON)
    x.report {
      puts "JSON.parse"
      times.times {
        JSON.parse(data, :max_nesting => false)
      }
    }
  end
  if defined?(ContrivedJSON::JSON)
    x.report {
      puts "ContrivedJSON::JSON.parse"
      times.times {
        ContrivedJSON::JSON.parse(data)
      }
    }
  end
  if defined?(Yajl::Parser)
    string_parser = Yajl::Parser.new
    
  x.report {
    puts "Yajl::Parser#parse (from a String)"
    times.times {
      string_parser.parse(json)
    }
  }
  end
  

end
