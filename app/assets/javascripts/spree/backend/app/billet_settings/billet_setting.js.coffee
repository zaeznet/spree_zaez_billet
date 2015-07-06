#= require_self
class window.BilletSetting
  afterConstructor: ->

  beforeConstructor: ->

  constructor: (defaultExecution = true) ->
    do @beforeConstructor
    do @defaultExecution if defaultExecution
    do @afterConstructor

  defaultExecution: ->
    @setBankForm()
    $('#bank').change => do @setBankForm

  # Verifica qual banco foi selecionado
  # e monta o formulario dele
  setBankForm: ->
    switch $('#bank').val()
      when 'banco_brasil' then @setBancoBrasil()
      when 'caixa' then  @setCaixa()
      when 'itau' then @setItau()
      when 'bradesco' then @setBradesco()
      when 'hsbc' then @setHsbc()
      when 'santander' then @setSantander()
      when 'sicredi' then @setSicredi()
      else @clearForm()

  # Exibe os campos utilizados pelo Banco do Brasil
  setBancoBrasil: ->
    @clearForm()
    $('#agreement_box, #wallet_box, #variation_wallet_box').show()

  # Exibe os campos utilizados pela Caixa
  setCaixa: ->
    @clearForm()
    $('#agreement_box, #account_digit_box, #app_version_box').show()

  # Exibe os campos utilizados pelo Itau
  setItau: ->
    @clearForm()
    $('#account_digit_box, #wallet_box, #agreement_box').show()

  # Exibe os campos utilizados pelo Bradesco
  setBradesco: ->
    @clearForm()
    $('#account_digit_box, #wallet_box, #company_code_box').show()

  # Exibe os campos utilizados pelo HSBC
  setHsbc: ->
    @clearForm()
    $('#wallet_box').show()

  # Exibe os campos utilizados pelo Santander Banespa
  setSantander: ->
    @clearForm()
    $('#wallet_box, #agreement_box').show()

  # Exibe os campos utilizados pelo Sicredi
  setSicredi: ->
    @clearForm()
    $('#wallet_box, #byte_idt_box, #office_code_box').show()

  # Esconde todos os campos que nao sao comum a todos os bancos
  clearForm: ->
    $('#account_digit_box, #agreement_box, #wallet_box, #variation_wallet_box, #app_version_box, #company_code_box, #office_code_box, #byte_idt_box').hide()