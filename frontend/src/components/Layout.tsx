import React, { useState } from 'react';
import './styles/Layout.css';
import { Link, useLocation } from 'react-router-dom';
import HomeIcon from '@mui/icons-material/Home';
import BarChartIcon from '@mui/icons-material/BarChart';
import PersonIcon from '@mui/icons-material/Person';
import PictureAsPdfIcon from '@mui/icons-material/PictureAsPdf';
import SettingsIcon from '@mui/icons-material/Settings';
import HelpIcon from '@mui/icons-material/Help';
import MenuIcon from '@mui/icons-material/Menu';
import NotificationsIcon from '@mui/icons-material/Notifications';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import ExitToAppIcon from '@mui/icons-material/ExitToApp';

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [isDropdownOpen, setDropdownOpen] = useState(false);
  const location = useLocation();

  const toggleDropdown = () => {
    setDropdownOpen(!isDropdownOpen);
  };

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="logo">
          <img src="/logo.png" alt="Logo" />
        </div>
        <nav className="menu">
          <Link to="/home" className={location.pathname === '/home' ? 'active' : ''}>
            <HomeIcon />
          </Link>

          <a href="/turnover">
            <BarChartIcon />
          </a>
          <Link to="/Employee" className={location.pathname === '/Employee' ? 'active' : ''}>
            <PersonIcon />
          </Link>

          <a href="#">
            <PictureAsPdfIcon />
          </a>
        </nav>
        <div className="bottom-menu">
          <a href="#">
            <SettingsIcon />
          </a>
          <a href="#">
            <HelpIcon />
          </a>
        </div>
      </aside>

      <div className="main">
        <header className="navbar">
          <div className="menu-toggle">
            <MenuIcon />
          </div>
          <div className="nav-icons">
            <NotificationsIcon />
            <div className="user-menu">
              <AccountCircleIcon onClick={toggleDropdown} />
              {isDropdownOpen && (
                <div className="dropdown-menu">
                  <div className="dropdown-header">My Account</div>
                  <Link to="/AccountSettings" className="dropdown-item">
                    <PersonIcon /> Account Settings
                  </Link>
                  <a href="#" className="dropdown-item">
                    <ExitToAppIcon /> Logout
                  </a>
                </div>
              )}
            </div>
          </div>
        </header>

        <main className="content">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;