resource "google_service_account" "default" {
  account_id   = "113370964294922053823"
  display_name = "Service Account"
}

resource "google_compute_instance" "myVM" {
  name         = var.vm_name
  machine_type = "n1-standard-1"
  zone         = var.zone

  tags = ["testeVM", "firstV", "prod"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230213"
      labels = {
        my_label = "myVM"
      }
    }
  }

  # Habilita rede para a VM com um IP público
  network_interface {
    network = "default" # Estamos usando a VPC default que já vem por padrão no projeto.

    access_config {
    // A presença do bloco access_config, mesmo sem argumentos, garante que a instância estará acessível pela internet.
    }
  }

  metadata = {
    Stage = "prod"
  }

  metadata_startup_script = "echo hi > /administration.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "839204131948-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

resource "google_artifact_registry_repository" "labdevops-artifact-registry" {
  location = var.region
  repository_id = "labdevops"
  description = "Imagens Docker"
  format = "DOCKER"
}