namespace :server do
  desc "connect to remote server"
  task :connect do
    Kernel.system("ssh -i ~/.ssh/livrodaclasse_rsa deploy@hedra.com.br")
  end

  desc "tail production log"
  task :log do
    Kernel.system("ssh -i ~/.ssh/livrodaclasse_rsa deploy@hedra.com.br 'tail -f ~/apps/hedra-site/current/log/production.log'")
  end

  desc "returns a production console"
  task :console do
    Kernel.exec("ssh -i ~/.ssh/livrodaclasse_rsa deploy@hedra.com.br  'cd ~/apps/hedra-site/current/; bundle exec rails c production'")
  end

  desc "updates XML sitemap"
  task :sitemap do
    Kernel.exec("ssh -i ~/.ssh/livrodaclasse_rsa deploy@hedra.com.br 'cd ~/apps/hedra-site/current/; rake sitemap:refresh'")
  end
end