terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.49.1"
    }
  }
}

# api_token is mandatory but cloudflare_ip_ranges doesn't require real authentication
provider "cloudflare" {
  api_token = "fakefakefakefakefakefakefakefakefakefake"
}

data "cloudflare_ip_ranges" "main" {}
