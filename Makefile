apply:
	@rm -rf .terraform
	@git pull
	@terraform init
	@terraform apply -auto-approve -var-file=terraform.tfvars

prod-destroy:
	@rm -rf .terraform
	@terraform init -backend-config=env-prod/state.tfvars
	@terraform destroy -auto-approve  -var-file=terraform.tfvars