function temp_surr_cluster_size = bodySPM_glm_helper(surromodel,tempdata,corrtype,mask,bwmask,th);
                    
                    surrocorr=abs(reshape(corr(tempdata',surromodel,'type',corrtype),size(mask)));
                    surrocorr=surrocorr.*bwmask;
                    temp_surr_cluster_size=zeros(1,length(th));
                    for thID=1:length(th)
                        tempclusters=bwlabel(surrocorr>th(thID),4);
                        if(max(tempclusters(:))>0)
                            vals=unique(tempclusters);
                            vals(1)=[];
                            ccount=histc(tempclusters(:),vals);
                            temp_surr_cluster_size(thID)=max(ccount);
                        end
                    end

