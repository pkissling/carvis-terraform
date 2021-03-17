default: dev

dev:
	terraform workspace select dev
	terraform apply

live:
	terraform workspace select live
	terraform apply -var 'env=live'
