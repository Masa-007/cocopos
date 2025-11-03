import { Application } from "@hotwired/stimulus";
import SeasonController from "./season_controller";
import CalendarTooltipController from "./calendar_tooltip_controller";

const application = Application.start();

application.register("season", SeasonController);
application.register("calendar-tooltip", CalendarTooltipController);
