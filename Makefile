get-credentials:
	gcloud container clusters get-credentials celero-cluster --zone southamerica-east1-c --project sicredi-prod
context_prod_sicredi:
	kubectl config use-context gke_sicredi-prod_southamerica-east1-c_celero-cluster
context_dev_celero_finance:
	kubectl config use-context gke_celero-finance-develop_us-east1-b_celero-clusterv2
