resource "google_compute_instance" "dev-env" {
  name         = var.vm_name
  machine_type = "n1-standard-1"
  zone         = var.zone
  
  tags = ["new-vm", "vm-prod"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230213"
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

  metadata_startup_script = '# ! /bin/bash  
                              apt update
                              apt -y install ansible
                              git clone https://github.com/DouglasNatan/dev-env.git
                              cd dev-env
                              ansible-playbook playbook.yml -i inventory
                              cat <<EOF > /var/www/html/index.html
                              <html><body><p>Linux startup script added directly.</p></body></html>
                              EOF'

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "terraform-new@douglasnatan-labdevops.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

resource "google_artifact_registry_repository" "labdevops-artifact-registry" {
  location = var.region
  repository_id = "labdevops"
  description = "Imagens Docker"
  format = "DOCKER"
}