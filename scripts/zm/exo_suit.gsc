#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	thread onplayerconnected();
}

onplayerconnected()
{
	level endon("end_game");
	for(;;)
	{
		level waittill("connected", player);
		player thread exo_suit();
		//player SetMoveSpeedScale(1.5);
	}
}

exo_suit()
{
	self endon("disconnect");
	level endon("end_game");
	self.sprint_boost = 0;
	self.jump_boost = 0;
	self.slam_boost = 0;
	self.exo_boost = 100;
	self thread monitor_exo_boost();
	while(1)
	{
		if( !self IsOnGround() )
		{
			if(self JumpButtonPressed() || self SprintButtonPressed())
			{
				wait_network_frame();
				continue;
			}
			self.sprint_boost = 0;
			self.jump_boost = 0;
			self.slam_boost = 0;
			while( !self IsOnGround() )
			{
				if( self JumpButtonPressed() && self.jump_boost < 1 && self.exo_boost >= 20 )
				{
					self.is_flying_jetpack = true;
					self.jump_boost++;
					angles = self getplayerangles();
					angles = (0,angles[1],0);
					
					self.loop_value = 2;
					
					if( IsDefined(self.loop_value))
					{
						Earthquake( 0.22, .9, self.origin, 850 );
						direction = AnglesToUp(angles) * 500;
						self thread land();
						for(l = 0; l < self.loop_value; l++)
						{
							self SetVelocity( (self GetVelocity()[0], self GetVelocity()[1], 0) + direction );
							wait_network_frame();
						}
					}
					self.exo_boost -= 20;
					self thread monitor_exo_boost();
				}
				if( self SprintButtonPressed() && self.sprint_boost < 1 && self.exo_boost >= 20 )
				{
					self.is_flying_jetpack = true;
					self.sprint_boost++;
					xvelo = self GetVelocity()[0];
                    yvelo = self GetVelocity()[1];
                    l = Length((xvelo, yvelo, 0));
                    if(l < 10)
                        continue;
                    if(l < 190)
                    {
                        xvelo = int(xvelo * 190/l);
                        yvelo = int(yvelo * 190/l);
                    }

					Earthquake( 0.22, .9, self.origin, 850 );
					if(self.jump_boost == 1)
						boostAmount = 2.25;
					else
						boostAmount = 3;
					self thread land();
					self SetVelocity( (xvelo * boostAmount, yvelo * boostAmount, self GetVelocity()[2]) );
					self.exo_boost -= 20;
					self thread monitor_exo_boost();
					while( !self isOnGround() )
						wait .05;
				}
				if( self StanceButtonPressed() && self.jump_boost > 0 && self.slam_boost < 1 && self HasPerk("specialty_rof") && self.exo_boost >= 30)
				{
					self.slam_boost++;
					self SetVelocity((self GetVelocity()[0], self GetVelocity()[1], -200));
					self thread land();
					self.exo_boost -= 30;
					self thread monitor_exo_boost();
				}
				wait_network_frame();
			}
			if(self.slam_boost > 0)
			{
				self EnableInvulnerability();
				RadiusDamage( self.origin, 200, 3000, 500, self, "MOD_GRENADE_SPLASH" );
				self DisableInvulnerability();
				self PlaySound( "zmb_phdflop_explo" );
				fx = loadfx("explosions/fx_default_explosion");
				playfx( fx, self.origin );
			}
		}
		wait_network_frame();
	}
}

monitor_exo_boost()
{
	self endon("disconnect");
	self notify("boostMonitor");
	self endon("boostMonitor");
	while(1)
	{
		while(self.exo_boost >= 100)
		{
			wait_network_frame();
		}
		wait 3;
		while(self.exo_boost < 100)
		{
			self.exo_boost += 5;
			wait 0.25;
		}
	}
}

land()
{
	self endon("disconnect");
	while( !self IsOnGround() )
		wait_network_frame();
	self.is_flying_jetpack = false;
}
