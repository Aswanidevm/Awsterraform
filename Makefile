apply:
	@rm -rf .terraform
	@git pull
	@terraform init
	@terraform apply -auto-approve -var-file=terraform.tfvars

destroy:
	@rm -rf .terraform
	@terraform init
	@terraform destroy -auto-approve  -var-file=terraform.tfvars