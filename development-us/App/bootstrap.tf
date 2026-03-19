module "tfstate_backend" {
  source      = "../../modules/tfstate_backend"
  environment = local.environment
  name        = "my-app"
}
