require 'spree_core'
require 'spree_zaez_billet/engine'
require 'brcobranca'

Spree::PermittedAttributes.source_attributes.push [:order_id, :due_date, :status]
