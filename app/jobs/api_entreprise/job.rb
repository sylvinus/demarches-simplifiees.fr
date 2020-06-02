class ApiEntreprise::Job < ApplicationJob
  DEFAULT_MAX_ATTEMPTS_API_ENTREPRISE_JOBS = 5
  def max_attempts
    ENV[MAX_ATTEMPTS_API_ENTREPRISE_JOBS].to_i || DEFAULT_MAX_ATTEMPTS_API_ENTREPRISE_JOBS
  end
end
