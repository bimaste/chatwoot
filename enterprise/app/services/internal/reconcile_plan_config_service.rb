class Internal::ReconcilePlanConfigService
  def perform
    remove_premium_config_reset_warning
    return if ChatwootHub.pricing_plan != 'community'

    create_premium_config_reset_warning if premium_config_reset_required?

    reconcile_premium_config
    reconcile_premium_features
  end

  private

  def config_path
    @config_path ||= Rails.root.join('enterprise/config')
  end

  def premium_config
    @premium_config ||= YAML.safe_load(File.read("#{config_path}/premium_installation_config.yml")).freeze
  end

  def remove_premium_config_reset_warning
    Redis::Alfred.delete(Redis::Alfred::CHATWOOT_INSTALLATION_CONFIG_RESET_WARNING)
  end

  def create_premium_config_reset_warning
    Redis::Alfred.set(Redis::Alfred::CHATWOOT_INSTALLATION_CONFIG_RESET_WARNING, true)
  end

  def premium_config_reset_required?
    premium_config.any? do |config|
      config = config.with_indifferent_access
      existing_config = InstallationConfig.find_by(name: config[:name])
      existing_config&.value != config[:value] if existing_config.present?
    end
  end

  def reconcile_premium_config
    premium_config.each do |config|
      new_config = config.with_indifferent_access
      existing_config = InstallationConfig.find_by(name: new_config[:name])
      next if existing_config&.value == new_config[:value]

      existing_config&.update!(value: new_config[:value])
    end
  end

  def premium_features
    @premium_features ||= YAML.safe_load(File.read("#{config_path}/premium_features.yml")).freeze
  end

  def reconcile_premium_features
    Rails.logger.info '⭐ Reconciliação de features premium desativada pelo override'

    # Em vez de desativar, vamos ATIVAR todas as features para todas as contas
    all_features = Enterprise::Billing::HandleStripeEventService::STARTUP_PLAN_FEATURES +
                   Enterprise::Billing::HandleStripeEventService::BUSINESS_PLAN_FEATURES +
                   Enterprise::Billing::HandleStripeEventService::ENTERPRISE_PLAN_FEATURES

    Account.find_in_batches do |accounts|
      accounts.each do |account|
        # Ativar features em vez de desativá-las
        account.enable_features(*all_features)

        # Registrar como features gerenciadas manualmente
        service = Internal::Accounts::InternalAttributesService.new(account)
        service.manually_managed_features = all_features

        account.save!
      end
    end
  end
end

Rails.application.config.to_prepare do
  # Parte 1: Sobrescrever o serviço de reconciliação que remove features
  Internal::ReconcilePlanConfigService.class_eval do
    # Substitui o método que desativa resources premium
    def reconcile_premium_features
      Rails.logger.info '⭐ Reconciliação de features premium desativada pelo override'

      # Em vez de desativar, vamos ATIVAR todas as features para todas as contas
      all_features = Enterprise::Billing::HandleStripeEventService::STARTUP_PLAN_FEATURES +
                     Enterprise::Billing::HandleStripeEventService::BUSINESS_PLAN_FEATURES +
                     Enterprise::Billing::HandleStripeEventService::ENTERPRISE_PLAN_FEATURES

      Account.find_in_batches do |accounts|
        accounts.each do |account|
          # Ativar features em vez de desativá-las
          account.enable_features(*all_features)

          # Registrar como features gerenciadas manualmente
          service = Internal::Accounts::InternalAttributesService.new(account)
          service.manually_managed_features = all_features

          account.save!
        end
      end
    end

    # Sobrescreve o método de verificação para nunca mostrar o aviso
    def premium_config_reset_required?
      false
    end
  end

  # Parte 2: Sobrescrever os métodos adicionais (como no plano anterior)
  Internal::Accounts::InternalAttributesService.class_eval do
    def valid_feature_list
      Enterprise::Billing::HandleStripeEventService::STARTUP_PLAN_FEATURES +
        Enterprise::Billing::HandleStripeEventService::BUSINESS_PLAN_FEATURES +
        Enterprise::Billing::HandleStripeEventService::ENTERPRISE_PLAN_FEATURES
    end

    def enable_all_features_permanently!
      self.manually_managed_features = valid_feature_list
    end
  end

  Enterprise::Billing::HandleStripeEventService.class_eval do
    def disable_all_premium_features
      Rails.logger.info 'Feature downgrade desativado pelo override'
    end

    def enable_plan_specific_features
      all_features = STARTUP_PLAN_FEATURES + BUSINESS_PLAN_FEATURES + ENTERPRISE_PLAN_FEATURES
      account.enable_features(*all_features)

      # Armazena como features gerenciadas manualmente
      service = Internal::Accounts::InternalAttributesService.new(account)
      service.manually_managed_features = all_features
    end
  end
end
