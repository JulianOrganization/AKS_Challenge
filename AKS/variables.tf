variable "resource_group_location" {
  type        = string
  default     = "northeurope" # Location der Ressourcen festlegen.
  description = "Standort der Resource Gruppe."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Präfix des Ressourcengruppennamens, der mit einer zufälligen ID kombiniert wird, damit der Name im Azure-Abonnement eindeutig ist."
}

variable "node_count" {
  type        = number
  description = "Die initiale Anzahl von Knoten für den Knotenpool."
  default     = 2 # Anzahl an Knoten.
}

variable "msi_id" {
  type        = string
  description = "Die Managed Service-Identitäts-ID. Wert festlegen, wenn dieses Programm mit Managed Identity als Authentifizierungsmethode ausgeführt wird."
  default     = null
}

variable "username" {
  type        = string
  description = "Der Administrator-Benutzername für den neuen Cluster."
  default     = "azureadmin"
}
