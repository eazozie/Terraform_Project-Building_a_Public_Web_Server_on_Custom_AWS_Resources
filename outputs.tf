output "instance_id" {
    description = "The id of the instance"
    value = aws_instance.Terraform_webserver.id
  
}

output "Elastic_ip" {
    description = "The elastic ip of the instance"
    value = aws_eip.one
  
}