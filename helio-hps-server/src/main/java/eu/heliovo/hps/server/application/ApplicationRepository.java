package eu.heliovo.hps.server.application;

import java.util.Collection;

public interface ApplicationRepository {

	public abstract Collection<AbstractApplicationDescription> getPresentApplications();

	public abstract AbstractApplicationDescription getApplication(String appId);

}