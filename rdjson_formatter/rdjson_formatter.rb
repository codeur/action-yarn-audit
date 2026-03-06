#!/usr/bin/env ruby
require 'json'

SEVERITY_RANK = {
  'critical' => 3,
  'high' => 3,
  'moderate' => 2,
  'low' => 1,
  'info' => 0,
  'none' => 0,
}.freeze

SEVERITY_LEVEL = ['UNKNOWN_SEVERITY', 'INFO', 'WARNING', 'ERROR'].freeze

lockfile_path = ARGV[0] || 'yarn.lock'
max_severity_rank = 0
diagnostics = []

# yarn audit outputs newline-delimited JSON
STDIN.each_line do |line|
  next if line.strip.empty?

  begin
    msg = JSON.parse(line)
  rescue JSON::ParserError
    warn "Failed to parse JSON: #{line}"
    next
  end

  next unless msg['type'] == 'auditAdvisory'

  data = msg['data']
  advisory = data['advisory']

  package_name = advisory['module_name']
  title = advisory['title']
  cve_id = advisory['cves']&.first || advisory['id']
  url = advisory['url']
  severity = advisory['severity'].to_s.downcase

  # Map yarn severity to rank
  severity_rank = SEVERITY_RANK[severity] || 0
  max_severity_rank = [max_severity_rank, severity_rank].max

  # Create message with fix guidance
  patched = advisory['recommendation'] || 'No fix available'
  message = "Title: #{title}\nSolution: #{patched}"

  # Find package line in yarn.lock
  # yarn.lock has package entries like: "package-name@^1.0.0:"
  line_num = `grep -n "^#{Regexp.escape(package_name)}@" "#{lockfile_path}" | head -1 | cut -d : -f 1`.to_i
  line_num = 0 if line_num.nil? || line_num.zero?

  diagnostic = {
    message: message,
    location: {
      path: lockfile_path,
      range: {
        start: {
          line: line_num,
          column: 0
        }
      }
    },
    severity: SEVERITY_LEVEL[severity_rank],
    code: {
      value: cve_id,
      url: url
    }
  }

  diagnostics.push(diagnostic)
end

output = {
  source: {
    name: 'yarn audit',
    url: 'https://github.com/yarnpkg/yarn'
  },
  severity: SEVERITY_LEVEL[max_severity_rank],
  diagnostics: diagnostics
}

puts output.to_json
