ActiveJob::QueueAdapters::DelayedJobAdapter.singleton_class.prepend(Module.new do
  def enqueue(job)
    provider_job = super
    job.provider_job_id = provider_job.id
    provider_job
  end

  def enqueue_at(job, timestamp)
    provider_job = super
    job.provider_job_id = provider_job.id
    provider_job
  end
end)