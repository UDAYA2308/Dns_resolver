def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)

	dns_records={}
	a={}
	cname={}
	dns_raw.each do |element|

		 records=element.split(",")

		 if(records[0].strip=="A")

			a[records[1].strip]=records[2].strip

		elsif (records[0].strip=="CNAME")

			cname[records[1].strip]=records[2].strip

		end
	
	end

	dns_records["A"]=a
	dns_records["CNAME"]=cname
	dns_records

end

def resolve(dns_records, lookup_chain, domain)


	if dns_records["A"].include?domain

		a=dns_records["A"]
		return lookup_chain.push(a[domain])
	
	elsif dns_records["CNAME"].include?domain

		cname=dns_records["CNAME"]

		if cname.include?domain

			lookup_chain.push(cname[domain])
			domain=cname[domain]
			return resolve(dns_records,lookup_chain,domain)

		end	

	end

	lookup_chain.pop
	lookup_chain.push("Error: record not found for "+domain)


end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
