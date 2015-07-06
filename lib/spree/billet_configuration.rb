class Spree::BilletConfiguration < Spree::Preferences::Configuration

  preference :bank,             :string             # banco
  preference :corporate_name,   :string             # nome do cedente
  preference :document,         :string             # documento (CPF/CNPJ) do cedente
  preference :address,          :string             # endereco do cedente
  preference :agency,           :string             # agencia
  preference :account,          :string             # conta corrente
  preference :account_digit,    :string             # digito da conta corrente (Caixa, Bradesco e Itaú)
  preference :app_version,      :string             # versao do aplicativo (Caixa)
  preference :company_code,     :string             # codigo da empresa (Bradesco)
  preference :agreement,        :string             # convenio
  preference :wallet,           :string             # carteira
  preference :variation_wallet, :string             # variacao carteira
  preference :office_code,      :string             # codigo do posto da cooperativa (Sicredi)
  preference :byte_idt,         :string             # Byte IDT (Sicredi)
  preference :due_date,      :integer, default: 5   # dias para o vencimento
  preference :acceptance,    :string,  default: 'N' # aceite (S/N)
  preference :instruction_1, :string                # 1a instrucao
  preference :instruction_2, :string                # 2a instrucao
  preference :instruction_3, :string                # 3a instrucao
  preference :instruction_4, :string                # 4a instrucao
  preference :instruction_5, :string                # 5a instrucao
  preference :instruction_6, :string                # 6a instrucao

  preference :registered,    :boolean, default: true  # emissao de remessa
  preference :shipping_number, :integer, default: 1   # codigo sequencial incrementado a cada remessa

  preference :doc_customer_attr, :string # atributo que representa o documento do cliente

end