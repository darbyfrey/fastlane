describe Match do
  describe Match::Storage::GitLab::Client do
    subject { described_class.new(
      api_v4_url: 'https://gitlab.example.com/api/v4', 
      project_id: 'sample/project',
      private_token: 'abc123') }

    describe '#base_url' do
      it 'returns the expected base_url for the given configuration' do
        expect(subject.base_url).to eq('https://gitlab.example.com/api/v4/projects/sample%2Fproject/secure_files')
      end
    end

    describe '#authentication_key' do
      it 'returns the job_token header key if job_token defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project', 
          job_token: 'abc123'
        )
        expect(client.authentication_key).to eq('JOB-TOKEN')
      end

      it 'returns private_token header key if private_key defined and job_token is not defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project', 
          private_token: 'xyz123'
        )
        expect(client.authentication_key).to eq('PRIVATE-TOKEN')      
      end

      it 'returns the job_token header key if both job_token and private_token are defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project', 
          job_token: 'abc123', 
          private_token: 'xyz123'
        )
        expect(client.authentication_key).to eq('JOB-TOKEN')      
      end
      
      it 'returns nil if job_token and private_token are both undefined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project'
        )
        expect(client.authentication_key).to be_nil           
      end
    end

    describe '#authentication_value' do
      it 'returns the job_token value if job_token defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project',
          job_token: 'abc123'
        )
        expect(client.authentication_value).to eq('abc123')
      end

      it 'returns private_token value if private_key defined and job_token is not defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project',
          private_token: 'xyz123'
        )
        expect(client.authentication_value).to eq('xyz123')      
      end

      it 'returns the job_token value if both job_token and private_token are defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project',
          job_token: 'abc123', 
          private_token: 'xyz123'
        )
        expect(client.authentication_value).to eq('abc123')      
      end
      
      it 'returns nil if job_token and private_token are both undefined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4', 
          project_id: 'sample/project'
        )
        expect(client.authentication_value).to be_nil           
      end
    end    

    describe '#files' do
      it 'returns an array of secure files for a project' do
        response = [
          { id: 1, name: 'file1' },
          { id: 2, name: 'file2' },
        ].to_json

        stub_request(:get, /gitlab.example.com/).
          with(headers: {'PRIVATE-TOKEN'=>'abc123'}).
          to_return(status: 200, body: response)

        files = subject.files
        expect(files.count).to be(2)
        expect(files.first.file.name).to eq('file1')
      end

      it 'returns an empty array if there are results' do
        stub_request(:get, /gitlab.example.com/).
          with(headers: {'PRIVATE-TOKEN'=>'abc123'}).
          to_return(status: 200, body: [].to_json)

        expect(subject.files.count).to be(0)      
      end

      it 'raises an exception for a non-json response' do
        stub_request(:get, /gitlab.example.com/).
          with(headers: {'PRIVATE-TOKEN'=>'abc123'}).
          to_return(status: 200, body: 'foo')
        
        expect{ subject.files }.to raise_error(JSON::ParserError)
      end
    end

  end
end