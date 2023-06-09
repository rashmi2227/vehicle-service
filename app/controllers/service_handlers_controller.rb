class ServiceHandlersController < ApplicationController
    before_action :authenticate_user_login!
    
    before_action :check_user , only: [:new, :create]

    before_action :check_permission

    def check_permission
        if current_user_login.role!='employee' && current_user_login.role!="admin" && current_user_login.role!='customer'
            flash[:notice]='You need admins permssion to access'
            redirect_to root_path
        end
    end

    def check_user
        if current_user_login.present? && current_user_login.role!='employee' && current_user_login.role!="admin" && current_user_login.role!='customer'
            flash[:notice]='Restricted Access'
            redirect_to root_path
        end
    end

    def create
        if current_user_login.present?
            if current_user_login.admin?
                primary_technician_id = params[:servicerequest][:primary_technician_id]
                vehicle_id = Servicerequest.find(params[:id]).vehicle_id
                user_id = Servicerequest.find(params[:id]).user_id
                # puts(user_id)
                vehicle_number = Vehicle.find(vehicle_id).vehicle_number
                servicerequestid = params[:id]
                Servicerequest.where(id: servicerequestid).update(primary_technician_id: primary_technician_id)
                services_array = params[:servicehandler][:subhandler]
                # p services_array
                services_array.each do |service|
                    ServiceHandler.create(user_id: user_id, employee_id: service, vehicle_id: vehicle_id, vehicle_number: vehicle_number, servicerequest_id: servicerequestid)
                end
                redirect_to '/serviceassigned/show'
            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def edit
        if current_user_login.present?
            if current_user_login.admin?
                @service_handler = ServiceHandler.joins(:servicerequest).select('service_handlers.*, servicerequests.*').find(params[:id])
                # @service_handlers = ServiceHandler.includes(:employee, servicerequest: :primary_technician).where.not(servicerequest_id: nil)
            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def index
        if current_user_login.present?
            if current_user_login.admin?
                @service_handlers = ServiceHandler.includes(:employee, servicerequest: :primary_technician).where.not(servicerequest_id: nil)
            else 
                flash[:notice]='Restricted Access'
                check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def alert 
        if current_user_login.present?
            if current_user_login.admin?
                
            else 
                flash[:notice]='Restricted Access'
                check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def checkstatus
        if current_user_login.present?
            if current_user_login.admin?
                @service_handler = ServiceHandler.find_by(id: params[:id])
                @servicerequest = Servicerequest.find_by(id: @service_handler.servicerequest_id)
                if @servicerequest.status == "done"
                    redirect_to '/service/edit'
                else
                    redirect_to "/service/edit/#{params[:id]}"
                end
            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def done
        if current_user_login.present?
            if current_user_login.admin?
    
            else 
                flash[:notice]='Restricted Access'
                check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def update
        if current_user_login.present?
            if current_user_login.admin?
                @service_handler = ServiceHandler.find(params[:id])
                @service_request = @service_handler.servicerequest  
                if params[:servicerequest][:primary_technician_id].empty?
                    @service_r = @service_request.primary_technician_id
                else  
                    @service_r = params[:servicerequest][:primary_technician_id]
                end
                if params.dig(:servicehandler, :employee_id)&.empty?
                    @service_h = @service_handler.employee_id
                else
                    @service_h = params.dig(:servicehandler, :employee_id)
                end                  
                # @service_r = params[:servicerequest][:primary_technician_id]
                # @service_h = params[:servicehandler][:employee_id]
                @service_id = @service_handler.servicerequest_id
                if ServiceHandler.where(employee_id: @service_r, servicerequest_id: @service_id).exists?
                    flash[:notice]='Primary Technician and Sub-Technician cannot be same'
                    redirect_to '/serviceassigned/show'
                elsif  Servicerequest.where(primary_technician_id: @service_h, id: @service_id).exists?
                    flash[:notice]='Primary Technician and Sub-Technician cannot be same'
                    redirect_to '/serviceassigned/show'
                elsif ServiceHandler.where(employee_id: @service_h, servicerequest_id: @service_id).exists?
                    flash[:notice]='Duplicate entry creation'
                    redirect_to '/serviceassigned/show'    
                else              
                    if @service_handler.update(employee_id: @service_h) || @service_request.update(primary_technician_id: @service_r)
                        redirect_to "/serviceassigned/show", notice: "Service handler updated successfully."
                    else
                        flash[:notice]='Error updating details'
                        redirect_to '/serviceassigned/show'
                    end
                end
            else 
                flash[:notice]='Restricted Access'
                check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def destroy
        if current_user_login.present?
            if current_user_login.admin?
                @service_handler = ServiceHandler.find(params[:id])
                if @service_handler.destroy
                    flash[:notice]='Handler deleted successfully!'
                    redirect_to '/serviceassigned/show'
                else   
                    flash[:notice]='Error deleting handler'
                    redirect_to '/serviceassigned/show'
                end
            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def existing
        if current_user_login.present?
            if current_user_login.admin?
    
            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def assignedservices
        if current_user_login.present?
            if current_user_login.customer?

            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def check
        if current_user_login.present?
            if current_user_login.customer?
                if Servicerequest.joins(:service_handlers).where(id: params[:id], status: 'pending') .exists?(service_handlers: { servicerequest_id: params[:id] })
                    redirect_to '/vehicles/alert'
                elsif Servicerequest.where(id: params[:id], status: 'done').exists? && Payment.where(servicerequest_id: params[:id], payment_status: 'unpaid').exists?
                    flash[:notice]='Payment is pending'
                    redirect_to '/payments/all'
                    # redirect_to '/vehcile/service/done'
                elsif Servicerequest.where(id: params[:id], status: 'done').exists? 
                    redirect_to '/vehcile/service/done'
                else
                    redirect_to "/service/delete/#{params[:id]}"
                end
            else 
              flash[:notice]='Restricted Access'
              check_current_user_role
            end
        else   
            flash[:notice]='Unauthorised Access'
            redirect_to root_path
        end 
    end

    def service_handler_params
        params.require(:service_handler).permit(:employee_id)
    end

    def service_request_params
        params.require(:service_handler).permit(:primary_technician_id)
    end

end
  