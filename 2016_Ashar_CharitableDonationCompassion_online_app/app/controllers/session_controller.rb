class SessionController < ApplicationController
  def disp
  	#new session- persist a new state machine, and save id in session
  	if session[:user_id] == nil  
  		@sess = Session.create
  		session[:user_id] = @sess.id
  		  		
  		
  	else #session already exists
  		@sess = Session.find(session[:user_id])
		@survey = @sess.survey
  			
  		#process responses and advance
		if form_is_valid?
			case @sess.state
			when 'targets', 'measures'
				if !params[:item].nil?
					@survey.save_items(params[:item], @sess.last) #process responses.  sess.last has target info.
				end
			when 'demographics'
				Demographic.create!(params[:demographic])  if !params[:demographic].nil? 
            end
                        
			create_form_token
			@ret = @sess.advance #advance stage if needed, return target or measure
		
		#invalid form, show last item again	
		else
			@ret = @sess.last
		end
		@demographic = Demographic.new if @sess.state == 'demographics' #to display correctly
	end
  end


private
	# Create a security token for use in sessions and forms
	def create_form_token
		num = (0..9).to_a
		session[:fid] = (0...32).to_a.map { |e| num[rand(10)] }.join('')
	end
	  
	# Check hidden form ID against token stored in session; ignore request if they don't match
	def form_is_valid?
		!params[:fid].nil? and (session[:fid].to_i == params[:fid].strip.to_i)
	end
	

end
