module.exports = {
  apps : [{
    name: 'api',
    exp_backoff_restart_delay: 10,
    script: './server.js'
  }]
};
