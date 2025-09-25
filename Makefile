SUBDIRS = \
    Personal \
    LandingZone \
    Keycloak \
    TechExploration \
    Observability/CN \
    Linux-K8S-OPS/CN \
    interview-qa/CN \
    interview-qa/EN \
    The-IndieDeveloper-Fullstack-Roadmap/EN \
    The-IndieDeveloper-Fullstack-Roadmap/CN

.PHONY: all $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
