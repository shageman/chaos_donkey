require 'json'

puts "\n:: WELCOME TO CF CHAOS DONKEY ::\n\n"

EXCLUDE_NAMES = %w(micro-walnut nats/0)

raw_instances = `aws ec2 describe-instances`

json_instances = JSON.parse(raw_instances)

instances = {}
json_instances["Reservations"].each do |reservation|
  reservation["Instances"].each do |instance|
    instance_id = instance["InstanceId"]
    name = instance["Tags"].select { |tag| tag["Key"] == "Name" }.first["Value"]
    if EXCLUDE_NAMES.include?(name)
      puts "Excluding #{instance_id} (#{name}), since we know we'd go down."
    else
      instances[instance_id] = name
    end
  end
end

puts "\nInstances in your installation:"
instances.each do |instance|
  puts " - #{instance.first} (#{instance.last})"
end

victim_id = instances.keys.sample

puts "\nInstance to be killed: #{victim_id} (#{instances[victim_id]})"

puts "Killing instance..."

Kernel.system ("aws ec2 terminate-instances --instance-ids #{victim_id}")
