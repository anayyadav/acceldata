output "endpoint_url" {
   description = "Endpoint url in the form address:port"
   value = join("", aws_db_instance.postgresql.*.endpoint)
}

output "endpoint_port" {
   description = "Endoint port"
   value = join("", aws_db_instance.postgresql.*.port)
}

output "endpoint_address" {
   description = "Endpoint address"
   value = join("", aws_db_instance.postgresql.*.address)
}